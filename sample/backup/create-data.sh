
if [ $# -ne 1 ]; then
  echo "missing or too many argument." 1>&2
  echo "You have to specify directory to write test data." 1>&2
  exit 1
fi

#create dummy folder
mkdir $1/2018052{0..9}
mkdir $1/2018053{0,1}
mkdir $1/2018060{1..9}

#create dummy backup data
dd if=/dev/zero of=testfile.dat bs=1k count=1

find $1 -regextype posix-basic -iregex "$1/[0-9]\{8\}" -exec cp ./testfile.dat {} \;

if [ $? -ne 0 ]; then
    echo "test data creation failed."
    exit 1
fi
 
echo "test data creation success."
exit 0
