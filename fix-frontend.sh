#!/usr/bin/expect -f
# Behebt Frontend-Probleme

set timeout 30
set password "0508"
set host "adam@raspberrypi.local"
set remote_path "~/relay-web-control"

puts "🔍 Diagnose und Reparatur"
puts "=========================="
puts ""

# Prüfe Service-Status
puts "📊 Prüfe Service-Status..."
spawn ssh $host "sudo systemctl status relay-web.service --no-pager"
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
puts "📁 Prüfe Dateien auf Raspberry Pi..."
spawn ssh $host "ls -la $remote_path/build/ 2>&1 | head -10"
expect {
    "password:" {
        send "$password\r"
        exp_continue
    }
    eof
}
wait

puts ""
puts "📤 Kopiere Frontend erneut..."
spawn scp -r build $host:$remote_path/
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

puts ""
puts "📤 Kopiere Backend erneut..."
spawn scp relay-web-backend.py $host:$remote_path/
expect {
    "password:" {
        send "$password\r"
        exp_continue
    }
    eof
}
wait

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
puts "⏳ Warte 3 Sekunden..."
sleep 3

puts ""
puts "📊 Prüfe Service-Status erneut..."
spawn ssh $host "sudo systemctl status relay-web.service --no-pager -l | head -20"
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
puts "✅ Fertig!"
puts ""
puts "🌐 Öffne im Browser: http://192.168.178.46:5000"
puts ""
puts "💡 Falls es immer noch nicht funktioniert:"
puts "   1. Prüfe ob build/index.html existiert: ssh $host 'ls -la $remote_path/build/'"
puts "   2. Prüfe Service-Logs: ssh $host 'sudo journalctl -u relay-web.service -n 50'"

