#!/bin/sh

# Run tests
RUBYOPT=-W1 bundle exec rake

if [ $? -ne 0 ] ; then
  echo "*** Some Tests failed"
  exit 1
fi

echo "*** Tests passed. Starting litmus"
echo

# Ensure fresh store directory
rm -rf /tmp/dav-file-store
mkdir /tmp/dav-file-store

# Run litmus test
bundle exec dav4rack --root /tmp/dav-file-store &

# Allow time for dav4rack to get started
sleep 3

DAV_PID=$?

if [ ! -f /tmp/litmus/litmus-0.13.tar.gz ]; then
  mkdir -p /tmp/litmus
  wget -O /tmp/litmus/litmus-0.13.tar.gz http://www.webdav.org/neon/litmus/litmus-0.13.tar.gz
  cd /tmp/litmus
  tar -xzf litmus-0.13.tar.gz
  cd /tmp/litmus/litmus-0.13
  ./configure
fi

cd /tmp/litmus/litmus-0.13
make URL=http://localhost:3000/ check
kill $DAV_PID

