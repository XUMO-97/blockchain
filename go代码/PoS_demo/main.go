package main

import (
	"bufio"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"github.com/davecgh/go-spew/spew"
	"github.com/joho/godotenv"
	"io"
	"log"
	"math/rand"
	"net"
	"os"
	"strconv"
	"sync"
	"time"
)

//全局变量
type Block struct {
	//Block是每个区块的内容
	Index     int
	Timestamp string
	BPM       int
	Hash      string
	PrevHash  string
	Validator string
}

//是我们的官方区块链,它只是一串经过验证的区块集合,每个区块中的PrevHash与前面块的Hash相比较,以确保我们的链是正确的
var Blockchain []Block
//tempBlocks是临时存储单元,在区块被选出来并添加到BlockChain之前,临时存储在这里
var tempBlocks []Block
//是Block的通道,任何一个节点在提出一个新块时都将它发到到这个通道
var candidateBlocks = make(chan Block)
//也是一个通道,我们的主GO TCP服务器将向所有节点广播最新的区块链
var announcements = make(chan string)
//是一个标准变量,允许我们控制读/写和防止数据竞争
var mutex = &sync.Mutex{}
//是节点的存储map,同时也会保存每个节点持有的令牌数
var validators = make(map[string]int)

//用来创建新块
func generateBlock(oldBlock Block, BPM int, address string) (Block, error) {
	var newBlock Block

	t := time.Now()

	newBlock.Index = oldBlock.Index + 1
	newBlock.Timestamp = t.String()
	newBlock.BPM = BPM
	newBlock.PrevHash = oldBlock.Hash            //存储上一个区块的Hash
	newBlock.Hash = calculateBlockHash(newBlock) //生成的Hash
	newBlock.Validator = address                 //存储的是获取记账权的节点地址

	return newBlock, nil
}

//该函数会接受一个string,并返回一个SHA256 hash
func calculateHash(s string) string {
	h := sha256.New()
	h.Write([]byte(s))
	hashed := h.Sum(nil)
	return hex.EncodeToString(hashed)
}

//对一个Block进行hash,将一个block的所有字段连接到一起后,再调用calculateHash将字符串转为SHA256 hash
func calculateBlockHash(block Block) string {
	record := string(block.Index) + block.Timestamp + string(block.BPM) + block.PrevHash
	return calculateHash(record)
}

//验证区块
func isBlockValid(newBlock, oldBlock Block) bool {
	if oldBlock.Index+1 != newBlock.Index {
		return false
	}

	if oldBlock.Hash != newBlock.PrevHash {
		return false
	}

	if calculateBlockHash(newBlock) != newBlock.Hash {
		return false
	}

	return true
}

/*
当一个验证这连接到我们的TCP服务,我们需要提供一些函数达到以下目标:
输入令牌的余额
接受区块链的最新广播
接受验证者赢得区块的广播信息
将自身节点添加到全局的验证者列表中
输入block的bpm数据,bpm是每个验证者的人体脉搏值
提议创建一个新的区块
 */

func handleConn(conn net.Conn) {
	defer conn.Close()

	go func() {
		for {
			msg := <-announcements
			io.WriteString(conn, msg)
		}
	}()
	//验证者地址
	var address string

	//验证者输入他所拥有的tokens,tokens 的值越大,越容易获取新区块的记账权
	io.WriteString(conn, "Enter token balance:")
	scanBalance := bufio.NewScanner(conn)
	for scanBalance.Scan() {
		//获取输入的数据,并将输入的值转为int
		balance, err := strconv.Atoi(scanBalance.Text())
		if err != nil {
			log.Printf("%v not a number: %v", scanBalance.Text(), err)
			return
		}
		t := time.Now()
		//生成验证者的地址
		address = calculateHash(t.String())
		//将验证者的地址和token 存储到validators
		validators[address] = balance
		fmt.Println(validators)
		fmt.Println(validators)
		break
	}

	io.WriteString(conn, "\nEnter a new BPM:")

	scanBPM := bufio.NewScanner(conn)

	go func() {
		for {
			for scanBPM.Scan() {
				bpm, err := strconv.Atoi(scanBPM.Text())
				//如果验证者试图提议一个被污染(例如伪造)的block,例如包含一个不是整数的BPM,那么程序会抛出一个错误,我们会立即从验证器列表validators中删除该验证者,他们将不再有资格参与到新块的铸造过程同时丢失相应的抵押令牌
				if err != nil {
					log.Printf("%v not a number: %v", scanBPM.Text(), err)
					delete(validators, address)
					conn.Close()
				}

				mutex.Lock()
				oldLastIndex := Blockchain[len(Blockchain)-1]
				mutex.Unlock()

				//创建新的区块,然后将其发送到candidateBlocks通道
				newBlock, err := generateBlock(oldLastIndex, bpm, address)
				if err != nil {
					log.Println(err)
					continue
				}
				if isBlockValid(newBlock, oldLastIndex) {
					candidateBlocks <- newBlock
				}
				io.WriteString(conn, "\nEnter a new BPM:")
			}
		}
	}()

	//循环会周期性的打印出最新的区块链信息
	for {
		time.Sleep(time.Minute)
		mutex.Lock()
		output, err := json.Marshal(Blockchain)
		mutex.Unlock()
		if err != nil {
			log.Fatal(err)
		}
		io.WriteString(conn, string(output)+"\n")
	}
}

func pickWinner() {
	time.Sleep(30 * time.Second)
	mutex.Lock()
	temp := tempBlocks
	mutex.Unlock()

	lotteryPool := []string{}
	if len(temp) > 0 {
	OUTER:
		for _, block := range temp {
			for _, node := range lotteryPool {
				if block.Validator == node {
					continue OUTER
				}
			}

			mutex.Lock()
			setValidators := validators
			mutex.Unlock()

			k, ok := setValidators[block.Validator]
			if ok {
				for i := 0; i < k; i++ {
					lotteryPool = append(lotteryPool, block.Validator)
				}
			}
		}

		s := rand.NewSource(time.Now().Unix())
		r := rand.New(s)
		lotteryWinner := lotteryPool[r.Intn(len(lotteryPool))]

		for _, block := range temp {
			if block.Validator == lotteryWinner {
				mutex.Lock()
				Blockchain = append(Blockchain, block)
				mutex.Unlock()
				for _ = range validators {
					announcements <- "\nwinning validator:" + lotteryWinner + "\n"
				}
				break
			}
		}
	}

	mutex.Lock()
	tempBlocks = []Block{}
	mutex.Unlock()
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal(err)
	}

	//创建初始区块
	t := time.Now()
	genesisBlock := Block{}
	genesisBlock = Block{0, t.String(), 0, calculateBlockHash(genesisBlock), "", ""}
	spew.Dump(genesisBlock)
	Blockchain = append(Blockchain, genesisBlock)

	httpPort := os.Getenv("PORT")

	//启动TCP服务
	server, err := net.Listen("tcp", ":"+httpPort)
	if err != nil {
		log.Fatal(err)
	}
	log.Println("HTTP Sever Listening on port :", httpPort)
	defer server.Close()

	//启动了一个Go routine 从candidateBlocks通道中获取提议的区块,然后填充到临时缓冲区tempBlocks中
	go func() {
		for candidata := range candidateBlocks {
			mutex.Lock()
			tempBlocks = append(tempBlocks, candidata)
			mutex.Unlock()
		}
	}()

	//启动了一个Go routine 完成 pickWinner函数
	go func() {
		for {
			pickWinner()
		}
	}()

	//接受验证者节点的连接
	for {
		conn, err := server.Accept()
		if err != nil {
			log.Fatal()
		}
		go handleConn(conn)
	}
}
