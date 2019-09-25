#!/bin/sh

#set -x

user=clearlinux
args'"-o StrictHostKeyChecking=no'

t=$(terraform output -json)
worker_ips=$(jq -r '.worker.value[].ipv4_address_private' <<< $t)
master_ips=$(jq -r '.master.value[].ipv4_address_private' <<< $t)

cat <<EOF > s.sh
choice=1
while [ \$choice!=0 ]; do
  echo ""
EOF

count=0
number=1
for m in $master_ips; do
  hostname=$(jq -r .master.value[$count].hostname <<< $t)
  echo "  echo $number $hostname" >> s.sh
  ((count = count + 1))
  ((number = number + 1))
done

count=0
for m in $worker_ips; do
  hostname=$(jq -r .worker.value[$count].hostname <<< $t)
  echo "  echo $number $hostname" >> s.sh
  ((count = count + 1))
  ((number = number + 1))
done

cat <<EOF >> s.sh
  echo 0. exit
  echo ""
  echo -n "Select: "
  read choice
  case \$choice in
EOF

count=0
number=1
for m in $master_ips; do
  hostname=$(jq -r .master.value[$count].hostname <<< $t)
  ip=$(jq -r .master.value[$count].ipv4_address_private <<< $t)
  echo "  $number) echo \"$hostname\"; ssh $args $user@$ip;;" >> s.sh
  ((count = count + 1))
  ((number = number + 1))
done

count=0
for m in $worker_ips; do
  hostname=$(jq -r .worker.value[$count].hostname <<< $t)
  ip=$(jq -r .worker.value[$count].ipv4_address_private <<< $t)
  echo "  $number) echo \"$hostname\"; ssh $args $user@$ip;;" >> s.sh
  ((count = count + 1))
  ((number = number + 1))
done

cat <<EOF >> s.sh
    *) echo ""; exit 0 ;;
  esac
done
EOF



jo -p all=$(jo vars=$(jo ansible_user=$user ansible_ssh_common_args=$args)) \
      nodes=$(jo children[]=cluster children[]=jh) \
      jh=$(jo hosts[]=jh.msk.pub) \
      cluster=$(jo children[]=master children[]=worker)\
      master=$(jo hosts=$(jo -a $master_ips)) \
      worker=$(jo hosts=$(jo -a $worker_ips))
