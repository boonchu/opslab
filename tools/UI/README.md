##### UI with whiptail 

text mode UI like whiptail become popular and ease adminstration for 
solution to use menu driven application on terminal side.

* Try this dialog box with hello world

```
$ whiptail --title "Hello World" --msgbox "Hello World from $LOGNAME" 7 78
```
![hello_world](https://github.com/boonchu/python3lab/blob/master/UI/hello_world.png)

* How about Thai recipe?

```
$ whiptail --title "Recipes" --checklist "choose recipes:" 10 78 4 padthai 'Pad Thai' ON tumyum 'Tum Yum Soup' OFF friedrice 'Thai Fried Rice' OFF 3>&1 1>&2 2>&3

here is output at prompt when I choose two recipes.
"tumyum" "friedrice"
```
![recipes](https://github.com/boonchu/python3lab/blob/master/UI/recipes.png)

* Progress bar

```
#!/bin/bash
{
    for ((i = 0 ; i <= 100 ; i+=5)); do
        sleep 0.1
        echo $i
    done
} | whiptail --gauge "Please wait while we are sleeping..." 6 50 0
```

Referenece: 
* http://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail
