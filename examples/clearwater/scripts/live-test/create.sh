#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

QUAFF_OLD_URL=git@github.com:metaswitch/quaff.git
QUAFF_NEW_URL=https://github.com/Metaswitch/quaff.git

# Build requirements
yes | aptdcon --hide-terminal --install build-essential
yes | aptdcon --hide-terminal --install bundler
yes | aptdcon --hide-terminal --install git

# For nokogiri Ruby gem
yes | aptdcon --hide-terminal --install zlib1g-dev

# Ruby 1.9 using Ruby enVironment Manager
if [ ! -d /usr/local/rvm ]; then
	# Install
	curl --location https://get.rvm.io | bash -s stable
	. /usr/local/rvm/scripts/rvm
	rvm autolibs enable
	rvm install 1.9.3
fi

# Install Clearwater Live Test
if [ ! -d /opt/clearwater-live-test ]; then
	mkdir --parents /opt
	cd /opt
	git clone --depth 1 https://github.com/Metaswitch/clearwater-live-test.git
	cd clearwater-live-test
	chmod a+rw -R .

	# Note: we must fix the URLs to Quaff
	sed --in-place --expression="s,$QUAFF_OLD_URL,$QUAFF_NEW_URL,g" Gemfile Gemfile.lock

	# Install Ruby
	. /usr/local/rvm/scripts/rvm
	rvm use 1.9.3@global
	bundle install
fi

# rake test[example.com] SIGNUP_CODE=secret PROXY=192.168.1.171 ELLIS=192.168.1.171
