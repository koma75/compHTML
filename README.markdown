compHTML - a Markdown file to HTML compiler v1.0
========================================================================

|||
|:--------- | :---------------------------- |
|Author     | Koma <okunoya@path-works.net> |
|Version    | 1.0                           |
|License    | BSD 2-clause license          |

Change History
------------------------------------------------------------------------
| Version | Date | Change History |
| ------: | ---: | :------------- |
| 1.0 | 2012.04.18 | First Release |

Configuration - 設定
------------------------------------------------------------------------
There is currently no configuration required for this program.
- - -
現在このプログラムには設定は有りません

Installation - インストール
------------------------------------------------------------------------
### Installing the compiled binary - バイナリファイルのインストール ###
Just place the compHTML.exe file anywhere you would like to install.
- - -
単純にcompHTMLファイルをお好きなフォルダに入れてお使い下さい

### Compiling from the source - ソースからコンパイルする場合 ###

You will be required to have the following installed

* Windows
    * Compilation is only available for Windows since it uses OCRA.
      For other platforms, use the script directly or use other 
      compilation scripts.
* Ruby 1.9.x or later 
    * Tested only on 1.9.3, but probably will work on 1.8.x
* Following Gems
    * [Redcarpet][]
    * [OCRA][]
    * [Rake][]

Do the Following to compile:
1. place all the files inside a folder
2. do '`cd /path/to/your/compHTML`' in your command line prompt
3. run '`rake`'

or just run the dorake.bat file...

this should produce compHTML.exe using the [OCRA][]
- - -
このプログラムをコンパイルして利用するためには以下の物が必要になります

* Windows
    * 現在コンパイルはOCRAを利用しているためWindowsのみとなっています。
      他のプラットフォームで利用する場合はそのままRubyで実行していただくか
      それぞれのパッケージシステムでパッケージしてください。
* Ruby 1.9.x 以降
    * 1.9.3でのみテスト済み。1.8.xでも動くかもしれません。
* 以下のGems
    * [Redcarpet][]
    * [OCRA][]
    * [Rake][]

以下を実行してコンパイルしてください:
1. ファイルを全て一つのフォルダに入れて下さい
2. '`cd /path/to/your/compHTML`' のようにコマンドプロンプトで上記のフォルダに移動してください。
3. '`rake`' を実行することでコンパイルされます。

上記で compHTML.exe が生成されるはずです。

Usage - 利用方法
------------------------------------------------------------------------
Using compHTML is as simple as drag-and-drop of markdown files to the executable.  At the moment, there is no settings or command line arguments.  In the future, I will try to implement some configuration to take in css files as well as some parameters for the Renderer.

All the files dropped to compHTML will be parsed as markdown files and will produce an html file of the name original-filename.markdown.html in the same directory as the original file.  If the file already exists, it will __*Overwrite*__ the file.
- - -
利用方法は単純です。compHTML.exeにmarkdown方式で記述したテキストファイルをドラッグ・アンド・ドロップしてください。現時点では設定やコマンドラインオプションなどは一切実装されていません。将来的には設定ファイルを利用したCSSファイルの指定等を実装する予定です。

ドラッグ・アンド・ドロップされたファイルは全てmarkdown方式で記述されたテキストファイルとしてパースされ、compHTML.cssを含んだHTMLファイルを元ファイルと同じ場所に生成します。生成するファイルは元ファイル名に".html"が付け加えられたものとなります。この際、同名のファイルが存在する場合は__*上書き*__されるため、ご注意下さい。

Known Bugs - 既知のバグ
------------------------------------------------------------------------
Not at the moment... Please contact the Author for any bugs.
現在特にありません。バグや機能要望については開発者までご連絡ください。

Credits - クレジット
------------------------------------------------------------------------
This work uses the following libraries and external works

* [Redcarpet][]
* clownfart [Markdown-CSS][]
    * the default compHTML.css is a derivative works of Markdown-CSS
* [OCRA][]
    * Used for compiling standalone executive
* [Ruby][] 1.9

[Redcarpet]:    https://github.com/tanoku/redcarpet         "Redcarpet"
[Markdown-CSS]: https://github.com/clownfart/Markdown-CSS   "Markdown-CSS"
[OCRA]:         http://ocra.rubyforge.org/  "One-Click Ruby Application"
[Rake]:         http://rake.rubyforge.org/ "Rake - Ruby Make"
[Ruby]:         http://www.ruby-lang.org/ "Ruby - A Programmer's Best Friend"

LICENSE - ライセンス
------------------------------------------------------------------------
Copyright (c) 2012, Koma
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

