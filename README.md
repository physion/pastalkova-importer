# Pastalkova Lab Ovation Import Tool

The `pastalkova-importer` package provides Matlab&reg code to import Pastalkova Lab behavior data sets.

## Requirements

- [Ovation](http://ovation.io) 2.0 or later
- [Ovation Matlab API Core](http:/ovation.io/downloads) installed and the [`+ovation`](https://github.com/physion/ovation-matlab/releases) package on the Matlab path


## Installation

1. Download the importer source by [downloading](https://github.com/physion/ovation-matlab/archive/master.zip) the source archive or cloning the GitHub repository.
2. Add the `src/` folder to your Matlab path


## Testing

Unit tests for the importer are written using the Matlab [`xunit`] test framework.

### Setup

 [Download](http://www.mathworks.com/matlabcentral/fileexchange/22846-matlab-xunit-test-framework) and install the `+xunit` package by adding it to your Matlab path. 

### Running tests
	
From within the `pastalkova-lab/` folder:

    >> addpath src
	>> runtests test



## License

Copyright (c) 2012-2013, Physion, LLC.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Matlab is a registered trademark of The Mathworks, Inc.