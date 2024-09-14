import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.5
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    width: 300
    height: 100

    property var priceChange: 0

    Timer {
        id: updateTimer
        interval: 60000 // Odświeżanie co 60 sekund
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetchPrice()
    }

    function fetchPrice() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                var price = response.bitcoin.usd;
                priceChange = response.bitcoin.usd_24h_change;
                updatePriceDisplay(price);
            }
        }
        xhr.send();
    }

    function updatePriceDisplay(price) {
        // Ustaw symbol strzałki i kolor w zależności od zmiany ceny
        if (priceChange >= 0) {
            arrowText.text = "\u25B2"; // Strzałka w górę
            arrowText.color = "green";
        } else {
            arrowText.text = "\u25BC"; // Strzałka w dół
            arrowText.color = "red";
        }
        priceText.text = "BTCUSD " + price.toFixed(2) + "$";
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: linkArea
            Layout.preferredWidth: priceGroup.width
            Layout.preferredHeight: priceGroup.height
            onClicked: {
                Qt.openUrlExternally("https://www.coingecko.com/pl/waluty/bitcoin");
            }

            Row {
                id: priceGroup
                spacing: 5
                anchors.centerIn: parent

                Text {
                    id: arrowText
                    text: ""
                    font.pixelSize: 24
                    font.family: "Digital-7 Mono"
                    color: "green"
                }

                Text {
                    id: priceText
                    text: "Ładowanie..."
                    font.pixelSize: 24
                    font.family: "Digital-7 Mono" // Upewnij się, że ta czcionka jest zainstalowana
                    color: "#00FF00" // Zielony kolor cyfrowego wyświetlacza
                }
            }
        }

        PlasmaComponents.Button {
            id: refreshButton
            text: "Odśwież"
            onClicked: fetchPrice()
        }
    }
}
