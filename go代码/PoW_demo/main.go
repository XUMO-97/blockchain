package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"github.com/davecgh/go-spew/spew"
	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

//difficulty表示难度系数,如果赋值为1,则需要判断生成区块时所产生的Hash前缀至少包含1个0
const difficulty = 1

//Block代表区块的结构体
type Block struct {
	Index		int		//是区块链中数据记录的位置
	Timestamp	string	//是自动确定的,并且是写入数据的时间
	BPM			int		//是每分钟跳动的次数,是你的脉率
	Hash  		string	//是代表这个数据记录的SHA256标识符
	PrevHash	string	//是链中上一条记录的SHA256标识符
	Difficulty	int		//当前区块的的难度系数
	Nonce		string	//是PoW挖矿中符合条件的数字
}

//Blockchain是存放区块数据的集合
var Blockchain []Block

//Message是使用POST请求传递的数据
type Message struct {
	BPM int
}

//是为了防止同一时间产生多个区块
var mutex = &sync.Mutex{}

//生成区块
func generateBlock(oldBlock Block, BPM int) Block {
	var newBlock Block

	t := time.Now()

	newBlock.Index = oldBlock.Index + 1
	newBlock.Timestamp = t.String()
	newBlock.BPM = BPM
	newBlock.PrevHash = oldBlock.Hash
	newBlock.Difficulty = difficulty

	//fot循环通过循环改变Nonce,然后选出符合相应难度的Nonce
	for i := 0; ;i++  {
		hex := fmt.Sprintf("%x", i)
		newBlock.Nonce = hex
		if !isHashValid(calculateHash(newBlock), newBlock.Difficulty) {
			fmt.Println(calculateHash(newBlock)," do more work!")
			time.Sleep(time.Second)
			continue
		}else{
			fmt.Println(calculateHash(newBlock)," work done!")
			newBlock.Hash = calculateHash(newBlock)
			break
		}
		return newBlock
	}
}

//isHashValid判断hash,是否满足当前的难度系数,如果难度系数是2,则当前hash的前缀有2个0
func isHashValid(hash string, difficulty int) bool {
	//strings.Repeat("0", difficulty)复制difficulty个0,并返回新字符串,当difficulty为2,则prefix为00
	prefix := strings.Repeat("0", difficulty)
	//strings.HasPrefix(hash, prefix)判断字符串hash是否包含前缀prefix
	return strings.HasPrefix(hash, prefix)
}

//calculateHahs根据设定的规则,生成Hash值
func calculateHash(block Block) string {
	record := strconv.Itoa(block.Index) + block.Timestamp + strconv.Itoa(block.BPM) + block.PrevHash + block.Nonce
	h := sha256.New()
	h.Write([]byte(record))
	hashed := h.Sum(nil)
	return hex.EncodeToString(hashed)
}

//验证区块,通过检查INdex来确保它们按预期递增,同时也检查以确保我们的PrevHash的确与Hash前一个区块相同,最后希望通过当前块上calculateHash再次运行该函数来检查当前块的散列,通过isBlockValid函数来完成以上事件并返回一个bool
func isBlockValid(newBlock, oldBlock Block) bool {
	if oldBlock.Index + 1 != newBlock.Index {
		return false
	}

	if oldBlock.Hash != newBlock.PrevHash {
		return false
	}

	if calculateHash(newBlock) != newBlock.Hash {
		return true
	}
}

//web服务器
func run() error {
	mux := makeMuxRouter()
	httpAddr := os.Getenv("ADDR")
	log.Println("listening on ", os.Getenv("ADDR"))
	s := &http.Server{
		Addr:				":" + httpAddr,
		Handler:			mux,
		ReadTimeout:    	10 * time.Second,
		WriteTimeout:  		10 * time.Second,
		MaxHeaderBytes:   	1 << 20,
	}

	if err := s.ListenAndServe(); err != nil {
		return err
	}

	return nil
}

//makeMuxRouter主要定义路由处理,当收到GET请求,就会调用handleGetBlockchain方法,当收到POST请求,就会调用handleWriteBLock方法
func makeMuxRouter() http.Handler {
	muxRouter := mux.NewRouter()
	muxRouter.HandleFunc("/", handleGetBlockchain).Methods("GET")
	muxRouter.HandleFunc("/",handleWriteBlock).Methods("POST")
	return muxRouter
}

//handleGetBlockchain获取所有区块的列表信息
func handleGetBlockchain(w http.ResponseWriter, r *http.Request)  {
	bytes, err := json.MarshalIndent(Blockchain, "", "		")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	io.WriteString(w, string(bytes))
}

//handleWriteBlock主要是生成新的区块
func handleWriteBlock(w http.ResponseWriter, r * http.Request)  {
	w.Header().Set("Content-Type", "application/json")
	var m Message

	decoder := json.NewDecoder(r.Body)
	if err := decoder.Decode(&m); err != nil {
		respondWithJSON(w, r, http.StatusBadRequest, r.Body)
		return
	}
	defer r.Body.Close()

	//ensure atomicity when creating new block
	mutex.Lock()
	newBlock := generateBlock(Blockchain[len(Blockchain)-1], m.BPM)
	mutex.Unlock()

	respondWithJSON(w, r, http.StatusCreated, newBlock)
}

func respondWithJSON(w http.ResponseWriter, r * http.Request, code int, payload interface{})  {
	w.Header().Set("Content-Type", "application/json")
	response, err := json.MarshalIndent(payload, "", "		")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("HTTP 500: Internal Sever Error"))
		return
	}
	w.WriteHeader(code)
	w.Write(response)
}

func main()  {
	//godotenv.Load()允许我们从根目录的.env读取相应的变量
	err := godotenv.Load()
	if err != nil {
		log.Fatal(err)
	}

	go func() {
		t := time.Now()
		//genesisBlock创建初始区块
		genesisBlock := Block{}
		genesisBlock = Block{0, t.String(), 0, calculateHash(genesisBlock), "", difficulty, ""}
		spew.Dump(genesisBlock)

		mutex.Lock()
		Blockchain = append(Blockchain, genesisBlock)
		mutex.Unlock()
	}()
	//run()启动web服务
	log.Fatal(run())
}