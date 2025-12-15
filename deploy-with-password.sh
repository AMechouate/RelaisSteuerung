#!/usr/bin/expect -f
# Deploy-Skript mit automatischer Passwort-Eingabe

set timeout 30
set password "0508"
set host "adam@192.168.178.46"
set build_dir "build"
set backend_file "relay-web-backend.py"
set remote_path "~/relay-web-control"

puts "🚀 Deploye Updates auf Raspberry Pi"
puts "====================================="
puts ""

# Prüfe ob build-Ordner existiert
if {![file exists $build_dir]} {
    puts "❌ build-Ordner nicht gefunden!"
    puts "   Bitte baue zuerst das Frontend: cd relay-web-frontend && npm run build"
    exit 1
}

# Kopiere Frontend
puts "📤 Kopiere Frontend..."
spawn scp -r $build_dir $host:$remote_path/
expect {
    "password:" {
        send "$password\r"
        exp_continue
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    eof
}
wait

# Kopiere Backend
puts ""
puts "📤 Kopiere Backend..."
spawn scp $backend_file $host:$remote_path/
expect {
    "password:" {
        send "$password\r"
        exp_continue
    }
    eof
}
wait

# Starte Service neu
puts ""
puts "🔄 Starte Service neu..."
spawn ssh $host "sudo systemctl restart relay-web.service"
expect {
    "password:" {
        send "$password\r"
        exp_continue
    }
    "sudo" {
        send "$password\r"
        exp_continue
    }
    eof
}
wait

puts ""
puts "✅ Deployment abgeschlossen!"
puts ""
puts "🌐 Öffne im Browser: http://192.168.178.46:5000"

