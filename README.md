# Miscellaneous bash setup

Clone this repo under the home directory, then run `setup.sh` there.
`setup.sh` makes links to everything here in home, if they don't already exists.

```
cd ~
git clone https://github.com/timkeith/misc.git
misc/setup.sh
```

## Contents

- .bash_aliases, bin -- aliases and scripts
- .vimrc, vim  -- Vim stuff
- all.epf -- eclipse preferences (File > Import > Preferences)
- .gitconfig  -- Git configuration  
    add credentials to ~/.git-credentials in this format:  
    `https://tim%40tkeith.com:passw0rd@github.com`
