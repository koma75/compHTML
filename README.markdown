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

Configuration - �ݒ�
------------------------------------------------------------------------
There is currently no configuration required for this program.
- - -
���݂��̃v���O�����ɂ͐ݒ�͗L��܂���

Installation - �C���X�g�[��
------------------------------------------------------------------------
### Installing the compiled binary - �o�C�i���t�@�C���̃C���X�g�[�� ###
Just place the compHTML.exe file anywhere you would like to install.
- - -
�P����compHTML�t�@�C�������D���ȃt�H���_�ɓ���Ă��g��������

### Compiling from the source - �\�[�X����R���p�C������ꍇ ###

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
���̃v���O�������R���p�C�����ė��p���邽�߂ɂ͈ȉ��̕����K�v�ɂȂ�܂�

* Windows
    * ���݃R���p�C����OCRA�𗘗p���Ă��邽��Windows�݂̂ƂȂ��Ă��܂��B
      ���̃v���b�g�t�H�[���ŗ��p����ꍇ�͂��̂܂�Ruby�Ŏ��s���Ă���������
      ���ꂼ��̃p�b�P�[�W�V�X�e���Ńp�b�P�[�W���Ă��������B
* Ruby 1.9.x �ȍ~
    * 1.9.3�ł̂݃e�X�g�ς݁B1.8.x�ł�������������܂���B
* �ȉ���Gems
    * [Redcarpet][]
    * [OCRA][]
    * [Rake][]

�ȉ������s���ăR���p�C�����Ă�������:
1. �t�@�C����S�Ĉ�̃t�H���_�ɓ���ĉ�����
2. '`cd /path/to/your/compHTML`' �̂悤�ɃR�}���h�v�����v�g�ŏ�L�̃t�H���_�Ɉړ����Ă��������B
3. '`rake`' �����s���邱�ƂŃR���p�C������܂��B

��L�� compHTML.exe �����������͂��ł��B

Usage - ���p���@
------------------------------------------------------------------------
Using compHTML is as simple as drag-and-drop of markdown files to the executable.  At the moment, there is no settings or command line arguments.  In the future, I will try to implement some configuration to take in css files as well as some parameters for the Renderer.

All the files dropped to compHTML will be parsed as markdown files and will produce an html file of the name original-filename.markdown.html in the same directory as the original file.  If the file already exists, it will __*Overwrite*__ the file.
- - -
���p���@�͒P���ł��BcompHTML.exe��markdown�����ŋL�q�����e�L�X�g�t�@�C�����h���b�O�E�A���h�E�h���b�v���Ă��������B�����_�ł͐ݒ��R�}���h���C���I�v�V�����Ȃǂ͈�؎�������Ă��܂���B�����I�ɂ͐ݒ�t�@�C���𗘗p����CSS�t�@�C���̎w�蓙����������\��ł��B

�h���b�O�E�A���h�E�h���b�v���ꂽ�t�@�C���͑S��markdown�����ŋL�q���ꂽ�e�L�X�g�t�@�C���Ƃ��ăp�[�X����AcompHTML.css���܂�HTML�t�@�C�������t�@�C���Ɠ����ꏊ�ɐ������܂��B��������t�@�C���͌��t�@�C������".html"���t��������ꂽ���̂ƂȂ�܂��B���̍ہA�����̃t�@�C�������݂���ꍇ��__*�㏑��*__����邽�߁A�����Ӊ������B

Known Bugs - ���m�̃o�O
------------------------------------------------------------------------
Not at the moment... Please contact the Author for any bugs.
���ݓ��ɂ���܂���B�o�O��@�\�v�]�ɂ��Ă͊J���҂܂ł��A�����������B

Credits - �N���W�b�g
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

LICENSE - ���C�Z���X
------------------------------------------------------------------------
Copyright (c) 2012, Koma
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

