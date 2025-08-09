#!/bin/bash

# XO Arena - Start Game Script
# Automatski pokreće igru u browser-u

echo "🎮 XO Arena - Pokretanje igre..."
echo "=================================="

# Proveri da li je port 8000 zauzet
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Port 8000 je zauzet. Prekidam postojeći proces..."
    lsof -ti:8000 | xargs kill -9
    sleep 2
fi

# Pređi u direktorijum sa igrom
cd "$(dirname "$0")"

echo "📁 Direktorijum: $(pwd)"
echo "🚀 Pokretam server na portu 8000..."

# Pokreni server u pozadini
python3 -m http.server 8000 > /dev/null 2>&1 &
SERVER_PID=$!

# Sačekaj da se server pokrene
sleep 3

# Proveri da li server radi
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 | grep -q "200"; then
    echo "✅ Server je uspešno pokrenut!"
    echo "🌐 Otvaram igru u browser-u..."
    
    # Otvori browser
    open http://localhost:8000
    
    echo ""
    echo "🎯 Igra je spremna!"
    echo "📱 Otvorite: http://localhost:8000"
    echo ""
    echo "💡 Kako igrati:"
    echo "   1. Kliknite 'Igraj vs AI' ili 'Igraj vs Player'"
    echo "   2. Odaberite težinu (ako igrate vs AI)"
    echo "   3. Kliknite na bilo koju tablu da je aktivirate"
    echo "   4. Kliknite na ćelije da napravite potez"
    echo "   5. Pobedite 4 od 8 tabla da pobedite igru"
    echo ""
    echo "🛑 Da zaustavite server, pritisnite Ctrl+C"
    
    # Sačekaj da korisnik pritisne Ctrl+C
    trap "echo ''; echo '🛑 Zaustavljam server...'; kill $SERVER_PID; echo '✅ Server je zaustavljen.'; exit" INT
    
    # Drži script aktivan
    while true; do
        sleep 1
    done
    
else
    echo "❌ Greška: Server se nije pokrenuo!"
    echo "🔧 Proverite da li je Python instaliran i da li ste u pravom direktorijumu."
    exit 1
fi
