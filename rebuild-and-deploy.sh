#!/usr/bin/expect -f
# Baut Frontend neu und kopiert es auf den Raspberry Pi

set timeout 30
set password "0508"
set host "adam@raspberrypi.local"
set remote_path "~/relay-web-control"

puts "🔨 Baue Frontend neu..."
puts "======================"
puts ""

# Baue Frontend
spawn cd relay-web-frontend && npm run build
expect {
    eof
}
wait

puts ""
puts "📤 Kopiere neuen build-Ordner auf Raspberry Pi..."
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
puts "✅ Fertig!"
puts ""
puts "🌐 Öffne im Browser: http://192.168.178.46:5000"

