# FAQ - 常见问题答疑  
本节主要整理一些常见问题，如Moonbeam组件使用方式、调试或运行中出现的问题、有益的改进方案等；

## Q1: Moonbeam是如何考虑使用Substrate和Polakdot的？
A: Substrate是开发Moonbeam的现有最优选择，它是功能强大的区块链开发框架。Moonbeam基于Substrate框架开发，可以物尽其用Substrate的各类功能，比如「开箱即用」功能等，从而省去从零开发的成本；Polkadot网络生态与Moonbeam相辅相成。作为Polkadot上的平行链，Moonbeam将能直接与网络上的任何平行链和平行线程集成，还可利用桥服务，帮助任何独立构建的（非Polkadot生态）链，连接Polkadot生态与外部网络，包括与以太坊桥接的转接桥。

## Q2: Moonbeam有哪几种开发运行方式？  
A: truffle box和native code编译方式；本地方式能更深入了解moonbeam具体实现，truffle box方式则更加自动化；也可以利用remix在线编译，并upload到moonbase alpha测试网。

## Q3: truffle run moonbeam install报错：Error:moonbeam-truffle-plugin listed as a plugin,but not found in global or local node modules!
![图1:报错截图](./p1.jpeg)   
A: 在$Path环境变量里面加上/.npm-global/bin/
