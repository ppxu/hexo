title: electron快速上手（译）
date: 2016-01-31 21:20:40
categories: nodejs
tags: [electron, atom, nodejs, chromium, app]
---
Electron可以让你使用纯JavaScript创建桌面应用程序，它提供了一个包含丰富的原生（操作系统）API的运行时。你可以把它看作是一个Node.js运行时的变体，只不过它是专注于桌面应用程序而不是web服务器。

这并不是说Electron是一个操作图形用户界面（GUI）库的JavaScript工具，实际上，Electron使用网页作为它的GUI，因此你也可以把它看作是一个精简版的Chromium浏览器，通过JavaScript来控制。

<!--more-->

### 主进程

在Electron中，运行`package.json`中的`main`脚本的进程叫作主进程（the main process）。主进程中运行的脚本可以通过创建网页来显示一个GUI界面。

### 渲染进程

由于Electron使用Chromium来显示网页，Chromium的多线程架构也用到了。Electron中的每一个网页都在一个独立的进程中运行，即渲染进程（the renderer process）。

在普通的浏览器中，网页通常是在一个沙箱环境中运行，不允许访问本地资源。不过使用Electron就可以在网页中利用Node.js的API来实现一些初级的操作系统交互。

### 主进程和渲染进程的区别

主进程通过创建`BrowserWindow`实例来生成网页，每个`BrowserWindow`实例在它自己的渲染进程中运行网页。当一个`BrowserWindow`实例销毁时，对应的渲染进程也被终止。

主进程管理所有的网页和它们相对应的渲染进程，每个渲染进程是独立的，只须关心在它上面运行的网页。

在网页中调用原生的GUI相关API是不允许的，因为在网页中管理原生GUI资源是十分危险的，很容易泄露资源。如果你想在网页中操作GUI，该网页的渲染进程必须要和主进程通信，请求在主进程上进行这些操作。

在Electron中，我们提供了[ipc](http://electron.atom.io/docs/v0.36.5/api/ipc-renderer)模块用来实现主进程和渲染进程之间的通信。另外还有一个[remote](http://electron.atom.io/docs/v0.36.5/api/remote)模块用来做RPC类型的通信。

## 编写你的第一个Electron应用

通常一个Electron应用的结构类似这样：

```
your-app/
├── package.json
├── main.js
└── index.html
```

`package.json`的格式和Node模块完全一样，`main`字段指定的脚本就是你的应用的启动脚本，它会运行主进程。一个`package.json`可能类似这样：

``` json
{
  "name"    : "your-app",
  "version" : "0.1.0",
  "main"    : "main.js"
}
```

__注意__：如果`package.json`中没有指定`main`字段，Electron会尝试加载`index.js`。

`main.js`需要创建窗口并且处理系统事件，一个典型的例子如下：

``` javascript
'use strict';

const electron = require('electron');
const app = electron.app;  // Module to control application life.
const BrowserWindow = electron.BrowserWindow;  // Module to create native browser window.

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
var mainWindow = null;

// Quit when all windows are closed.
app.on('window-all-closed', function() {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform != 'darwin') {
    app.quit();
  }
});

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
app.on('ready', function() {
  // Create the browser window.
  mainWindow = new BrowserWindow({width: 800, height: 600});

  // and load the index.html of the app.
  mainWindow.loadURL('file://' + __dirname + '/index.html');

  // Open the DevTools.
  mainWindow.webContents.openDevTools();

  // Emitted when the window is closed.
  mainWindow.on('closed', function() {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null;
  });
});
```

最后这个`index.html`就是你想要展现的网页：

``` html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Hello World!</title>
  </head>
  <body>
    <h1>Hello World!</h1>
    We are using node <script>document.write(process.versions.node)</script>,
    Chrome <script>document.write(process.versions.chrome)</script>,
    and Electron <script>document.write(process.versions.electron)</script>.
  </body>
</html>
```

## 运行你的应用

当你创建完最初的`main.js`，`index.html`和`package.json`文件，你肯定迫不及待想要在本地尝试跑一下你的应用，看看它是不是像预期那样的运行。

### electron-prebuilt

如果你通过`npm`全局安装了`electron-prebuilt`，你只需要在你的应用目录下运行：

``` javascript
electron .
```

如果你是局部安装的，运行：

``` javascript
./node_modules/.bin/electron .
```

### 手动下载的Electron程序

如果你是手动下载的Electron，你也可以直接运行你的应用。

#### Windows

``` bash
$ .\electron\electron.exe your-app\
```

#### Linux
``` bash
$ ./electron/electron your-app/
```

#### OSX
``` bash
$ ./Electron.app/Contents/MacOS/Electron your-app/
```

这里的`Electron.app`是Electron发行包中的一部分，你可以在[这里](https://github.com/atom/electron/releases)下载。

### 发布应用

当你完成了应用的开发，你可以根据[应用发布](http://electron.atom.io/docs/v0.36.5/tutorial/application-distribution)指南来创建一个发布，并执行打包程序。

### 尝试这个例子

在[atom/electron-quick-start](https://github.com/atom/electron-quick-start)下载并运行这个教程的代码。

__注意__：运行代码需要系统支持[Git](https://git-scm.com/)和[Node.js](https://nodejs.org/en/download/)（含[npm](https://npmjs.org/)）。

``` bash
# Clone the repository
$ git clone https://github.com/atom/electron-quick-start
# Go into the repository
$ cd electron-quick-start
# Install dependencies and run the app
$ npm install && npm start
```

__原文地址__：[http://electron.atom.io/docs/latest/tutorial/quick-start/](http://electron.atom.io/docs/latest/tutorial/quick-start/)
