---
mathjax: false
title: 二进制安全学习规划指南
date: 2018-04-04 00:09:57
---

> note of https://www.ichunqiu.com/course/56927

# Hacking三步曲

- 理解系统（Understanding）
  - 系统性的基础课程学习，深入理解计算机系统运作机制。
- 破坏系统（Breaking）
  - 学习与创造漏洞挖掘与利用技巧
- 重构系统（Reconstruction）
  - 设计与构建系统防护

# 基础课程学习

## 核心基础课程——计算机的工作原理

- **体系结构**

  - CPU的设计与实现
    - 机器指令与汇编语言
    - 指令的解码、执行
    - 内存管理
  - CMU 18-447 Introduction to Computer Architecture
    - https://www.ece.cmu.edu/~ece447/s15/doku.php
    - Labs: implement a MIPS CPU using Verilog

- **编译原理**

  - 编译器的设计与实现
    - 自动机、词法分析、句法分析
    - 运行时
    - 程序静态分析
  - Stanford CS-143 - Compilers
    - http://web.stanford.edu/class/cs143/
    - PA: Compilers for cool language

- **操作系统**

  - 操作系统的设计与实现

    - 系统的加载与引导
    - 用户态和内核态、系统调用、中断和驱动
    - 进程于内存管理、文件系统
    - 虚拟机

  - NT 6.828 - Operating System Engineering

    - https://pdos.csail.mit.edu/6.828/2016/

    - Labs: Implement jos

    - Xv6 , a simple Unix-like teaching operating system

## 其他基础课程——系统软件开发基础

- 编程语言

- 网络协议

- 算法与数据结构

# 漏洞挖掘与利用

## 快速入门——CTF

- 蓝莲花战队CTF成长秘诀——坚持超过一年的以赛代练
  - 9447CTF、CCC CTF、HITCON CTF、Plaid CTF、Boston Key Party、DEF CON CTF
- CTF 历史资料库：https://github.com/ctfs
- Wargames:
  - https://pwnable.kr/

  - http://smashthestack.org/

## 如何从CTF赛棍转型

- CTF 
  - 短时间（48h）、目标代码量少、漏洞容易发现、利用技巧千奇百怪
- 实战——长期做一道很难的CTF题
  - 长期（长年累月）、目标代码量大、漏洞难以发现、利用技术有套路可循

## 实战

- **目标**
  - 网络协议的实现
    - HTTP/SMB/DNS/UPnP Server
  - 脚本引擎
    - JavaScript Engine
    - ActionScript Engine
    - PHP/Java Sandbox Escape
  - 内核
    - Linux/Android
    - Freebsd
    - Apple iOS
    - Sony PS4
- **准备**
  - 学习历史漏洞 - CVEs
  - 挖掘新漏洞
    - 逆向分析+代码审计
      - 快速逆向与快速理解
      - 对漏洞的理解
    - 模糊测试
      - 测试框架
      - 样例生成的想法

# 构建系统防护

## 研究与探索

- 漏洞自动挖掘技术
  - 静态程序分析
  - 符号执行
  - 机器学习
- 漏洞利用防护机制
  - Intel SGX
  - 控制流完整性（CFI）
  - 拟态