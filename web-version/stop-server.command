#!/bin/bash

# XO Arena - Stop Server Script
# Zaustavlja server koji radi na portu 8000

echo "🛑 XO Arena - Zaustavljanje servera..."
echo "========================================"

# Proveri da li server radi na portu 8000
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "🔍 Pronašao sam server na portu 8000..."
    
    # Prekini proces
    SERVER_PID=$(lsof -ti:8000)
    echo "🔄 Prekidam proces PID: $SERVER_PID"
    
    kill -9 $SERVER_PID
    
    # Sačekaj da se proces zaustavi
    sleep 2
    
    # Proveri da li je proces zaustavljen
    if ! lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
        echo "✅ Server je uspešno zaustavljen!"
        echo "🎮 Port 8000 je sada slobodan."
    else
        echo "❌ Greška: Server se nije zaustavio!"
        echo "🔧 Pokušajte ponovo ili restartujte Terminal."
    fi
else
    echo "ℹ️  Server nije pokrenut na portu 8000."
    echo "🎮 Možete pokrenuti igru sa 'start-game.command'"
fi

echo ""
echo "💡 Da pokrenete igru ponovo, koristite:"
echo "   ./start-game.command"
echo ""
echo "🔄 Pritisnite Enter da zatvorite ovaj prozor..."
read
