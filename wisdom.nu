#!/usr/bin/env nu

def has-cmd [name: string] {
    (which $name | is-empty) == false
}

let text = if (has-cmd fortune) {
    fortune -s | str trim | str replace -r '\s+' ' '
} else {
    "Wisdom unavailable."
}

mut say_options = []

if (has-cmd cowsay) and (has-cmd lolcrab) {
    $say_options = ($say_options | append { |text: string|
        let cows = cowsay -l | str trim | split row --regex '\s+'
        if ($cows | length) == 0 {
            $text | cowsay | lolcrab
        } else {
            let cow = $cows | get (random int 0..<($cows | length))
            $text | cowsay -f $cow | lolcrab
        }
    })
}

if (has-cmd lolcrab) and ((has-cmd ponysay) or (has-cmd ponythink)) {
    $say_options = ($say_options | append { |text: string|
        let text = ($text | lolcrab -g cool)
        if (has-cmd ponysay) and ((not (has-cmd ponythink)) or (random bool)) {
            ponysay $text err> /dev/null
        } else if (has-cmd ponythink) {
            ponythink $text err> /dev/null
        } else {
            $text
        }
    })
}

if (has-cmd dinosay) and (has-cmd lolcrab) {
    $say_options = ($say_options | append { |text: string| dinosay -r $text | lolcrab })
}

if (has-cmd yosay) and (has-cmd lolcrab) {
    $say_options = ($say_options | append { |text: string| yosay ($text | lolcrab) })
}

if (has-cmd ricksay) {
    $say_options = ($say_options | append { |text: string| ricksay })
}

if ($say_options | length) == 0 {
    print $text
} else {
    let choice = random int 0..<($say_options | length)
    do ($say_options | get $choice) $text
}
