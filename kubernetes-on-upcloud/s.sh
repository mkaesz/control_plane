choice=1
while [ $choice!=0 ]; do
  echo ""
  echo 1 de-fra1-control-plane-master
  echo 2 de-fra1-control-plane-worker-0
  echo 3 de-fra1-control-plane-worker-1
  echo 4 de-fra1-control-plane-worker-2
  echo 0. exit
  echo ""
  echo -n "Select: "
  read choice
  case $choice in
  1) echo "de-fra1-control-plane-master"; ssh  clearlinux@10.4.6.202;;
  2) echo "de-fra1-control-plane-worker-0"; ssh  clearlinux@10.4.6.244;;
  3) echo "de-fra1-control-plane-worker-1"; ssh  clearlinux@10.4.1.191;;
  4) echo "de-fra1-control-plane-worker-2"; ssh  clearlinux@10.4.7.236;;
    *) echo ""; exit 0 ;;
  esac
done
