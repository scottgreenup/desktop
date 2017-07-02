

fortunes="
starwars
chucknorris
limericks
southpark
archlinux
metalocalypse
archer
futurama
montypython
blackbooks
blackadder
hitchhiker
protolol-git
vimtips
confucius
portal
portal2
kernelnewbies
"

echo -n "pacaur -S"

while read -r fortune; do
    if [[ "$fortune" != "" ]]; then
        echo -n " fortune-mod-${fortune}"
    fi
done <<< "$fortunes"

