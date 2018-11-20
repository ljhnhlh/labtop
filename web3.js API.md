### web3.js API 基本

工程引入web3：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181120102950260.png)

Big Number: getBalance获取到的是一个大数，需调用web3 的 BIgNumber 库，且计算时保证计单位为wei

API函数默认为同步调用



sendtransaction ：修改block chain上的数据，需要gas

call：查看数据，不消耗gas



**发起交易的方法**：对加入的account，获取其地址，计算费用时，使用下面的函数，from 和to地址使用交易双方的地址



![在这里插入图片描述](https://img-blog.csdnimg.cn/20181120105509812.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM2MzAzODYy,size_16,color_FFFFFF,t_70)

![1542682548865](C:\Users\林俊浩\AppData\Roaming\Typora\typora-user-images\1542682548865.png)

**使用指定账户签名要发送的数据**

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181120110216952.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM2MzAzODYy,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181120110258270.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM2MzAzODYy,size_16,color_FFFFFF,t_70)

