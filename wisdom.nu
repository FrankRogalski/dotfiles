#!/usr/bin/env nu

let say_options = [
    { |text: string|
        let cows = (cowsay -l | split row ':').1 | str trim | split row --regex '\s+'
        let cow = $cows | get (random int 0..<($cows | length))
        $text | cowsay -f $cow | lolcrab
    }
    { |text: string|
        let text = ($text | lolcrab -g cool)
        if (random bool) {
            ponysay $text err> /dev/null
        } else {
            ponythink $text err> /dev/null
        }
    }
    { |text: string| dinosay -r $text | lolcrab }
    { |text: string| yosay ($text | lolcrab) }
    { |text: string| ricksay }
]

let choice = random int 0..<($say_options | length)
do ($say_options | get $choice) (fortune -s)
