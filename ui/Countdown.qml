import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8

Item {
    id: countdownRoot

    property int initialTime: 20

    property int remainingTime: initialTime

    readonly property alias isRunning: countdownTimer.running

    signal finished()

    Timer {
        id: countdownTimer
        interval: 1000 
        repeat: true   // Keep firing every second while running
        running: false // Initially stopped

        onTriggered: {
            if (countdownRoot.remainingTime > 0) {
                // Decrease remaining time
                countdownRoot.remainingTime--;
            } else {
                // Stop the timer and emit signal when time runs out
                countdownTimer.stop();
                countdownRoot.finished();
            }
        }
    }

    function start() {
        // Reset time to initial value
        countdownRoot.remainingTime = countdownRoot.initialTime;
        countdownTimer.start();
    }

    function stop() {
        countdownTimer.stop();
    }

    function resume() {
        if (countdownRoot.remainingTime > 0) {
             countdownTimer.start();
        }
    }

    function reset() {
        countdownTimer.stop();
        countdownRoot.remainingTime = countdownRoot.initialTime;
    }

    Component.onDestruction: {
        countdownTimer.stop();
    }
}