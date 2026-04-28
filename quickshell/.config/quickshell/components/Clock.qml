import Quickshell
import Quickshell.Io
import QtQuick

Row {
    id: clock

    required property var theme
    required property string fontFamily
    required property int fontSize

    property string dateLabel: "Seg 27 Abr"
    property string timeLabel: Qt.formatDateTime(new Date(), "hh:mm")
    property string weatherLabel: "󰖐 --ºC"
    property string yearCalendarLabel: ""
    property string dateSummaryLabel: ""
    property string weatherTooltip: "Clima atual indisponivel."
    readonly property bool dateTooltipOpen: dateMouseArea.containsMouse

    onDateTooltipOpenChanged: {
        if (dateTooltipOpen) {
            dateTooltipCloseTimer.stop()
        } else {
            dateTooltipCloseTimer.start()
        }
    }

    spacing: theme.itemSpacing

    function weekdayShort(day) {
        return ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"][day]
    }

    function monthShort(month) {
        return ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"][month]
    }

    function padLeft(value, size) {
        var text = String(value)
        while (text.length < size) {
            text = " " + text
        }
        return text
    }

    function padRight(value, size) {
        var text = String(value)
        while (text.length < size) {
            text += " "
        }
        return text
    }

    function centerText(value, size) {
        var text = String(value)
        var left = Math.floor((size - text.length) / 2)
        var right = size - text.length - left
        return " ".repeat(Math.max(left, 0)) + text + " ".repeat(Math.max(right, 0))
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function dayOfYear(date) {
        var start = new Date(date.getFullYear(), 0, 0)
        var diff = date - start
        return Math.floor(diff / 86400000)
    }

    function isoWeek(date) {
        var target = new Date(date.valueOf())
        var dayNumber = (date.getDay() + 6) % 7
        target.setDate(target.getDate() - dayNumber + 3)
        var firstThursday = new Date(target.getFullYear(), 0, 4)
        var firstDayNumber = (firstThursday.getDay() + 6) % 7
        firstThursday.setDate(firstThursday.getDate() - firstDayNumber + 3)
        return 1 + Math.round((target - firstThursday) / 604800000)
    }

    function monthGrid(year, month) {
        var width = 20
        var monthName = [
            "Janeiro", "Fevereiro", "Marco", "Abril", "Maio", "Junho",
            "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
        ][month]
        var firstDay = new Date(year, month, 1).getDay()
        var totalDays = daysInMonth(year, month)
        var cells = []
        var lines = []

        for (var i = 0; i < firstDay; i += 1) {
            cells.push("  ")
        }

        for (var day = 1; day <= totalDays; day += 1) {
            cells.push(padLeft(day, 2))
        }

        while (cells.length % 7 !== 0) {
            cells.push("  ")
        }

        lines.push(centerText(monthName, width))
        lines.push("Do Se Te Qa Qi Se Sa")

        for (var row = 0; row < cells.length; row += 7) {
            lines.push(cells.slice(row, row + 7).join(" "))
        }

        while (lines.length < 8) {
            lines.push(" ".repeat(width))
        }

        return lines
    }

    function buildYearCalendar(year) {
        var lines = []
        var spacing = "    "

        lines.push(centerText(year, 68))
        lines.push("")

        for (var monthIndex = 0; monthIndex < 12; monthIndex += 3) {
            var first = monthGrid(year, monthIndex)
            var second = monthGrid(year, monthIndex + 1)
            var third = monthGrid(year, monthIndex + 2)

            for (var lineIndex = 0; lineIndex < first.length; lineIndex += 1) {
                lines.push(first[lineIndex] + spacing + second[lineIndex] + spacing + third[lineIndex])
            }

            if (monthIndex < 9) {
                lines.push("")
            }
        }

        // Non-breaking spaces keep the calendar columns aligned inside Text.
        return lines.join("\n").replace(/ /g, "\u00A0")
    }

    function refreshDateTime() {
        var now = new Date()
        var day = String(now.getDate()).padStart(2, "0")
        dateLabel = weekdayShort(now.getDay()) + " " + day + " " + monthShort(now.getMonth())
        timeLabel = Qt.formatDateTime(now, "hh:mm")
        dateSummaryLabel = "Semana " + isoWeek(now)
            + "  •  Dia " + dayOfYear(now) + " do ano"
        yearCalendarLabel = buildYearCalendar(now.getFullYear())
    }

    Item {
        id: dateChip

        implicitWidth: dateText.implicitWidth
        implicitHeight: dateText.implicitHeight

        Text {
            id: dateText
            anchors.centerIn: parent
            text: dateLabel
            color: theme.text
            font.family: clock.fontFamily
            font.pixelSize: clock.fontSize
            font.bold: true
        }

        MouseArea {
            id: dateMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }

        PopupWindow {
            visible: clock.dateTooltipOpen || dateTooltipCloseTimer.running
            color: "transparent"
            anchor.item: dateChip
            anchor.rect.x: dateChip.width / 2 - width / 2
            anchor.rect.y: dateChip.height + 8
            width: Math.max(calendarText.implicitWidth, calendarSummary.implicitWidth) + 24
            height: calendarColumn.implicitHeight + 20

            Rectangle {
                id: calendarCard
                anchors.fill: parent
                radius: 10
                color: theme.background
                border.color: theme.accent
                border.width: 1
                opacity: clock.dateTooltipOpen ? 1 : 0
                scale: clock.dateTooltipOpen ? 1 : 0.96
                y: clock.dateTooltipOpen ? 0 : -8

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on y {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutQuint
                    }
                }

                Column {
                    id: calendarColumn
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        id: calendarSummary
                        text: dateSummaryLabel
                        color: theme.text
                        font.family: clock.fontFamily
                        font.pixelSize: Math.max(clock.fontSize - 1, 11)
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        id: calendarText
                        text: yearCalendarLabel
                        textFormat: Text.PlainText
                        color: theme.text
                        font.family: clock.fontFamily
                        font.pixelSize: Math.max(clock.fontSize - 2, 10)
                        font.bold: false
                        wrapMode: Text.NoWrap
                    }
                }
            }
        }
    }

    InfoChip {
        text: timeLabel
        tooltipText: Qt.formatDateTime(new Date(), "dddd, dd/MM/yyyy\nhh:mm:ss")
        theme: clock.theme
        fontFamily: clock.fontFamily
        fontSize: clock.fontSize
        textColor: theme.text
    }

    InfoChip {
        text: weatherLabel
        tooltipText: weatherTooltip
        tooltipAlignment: Text.AlignLeft
        tooltipMaxWidth: 300
        theme: clock.theme
        fontFamily: clock.fontFamily
        fontSize: clock.fontSize
        textColor: theme.warning
    }

    Timer {
        // Date and time are derived locally, so a lightweight timer is enough.
        interval: 1000
        running: true
        repeat: true
        onTriggered: refreshDateTime()
    }

    Timer {
        // Weather changes slowly, so refresh it on a longer interval.
        interval: 900000
        running: true
        repeat: true
        onTriggered: weatherProc.running = true
    }

    Process {
        id: weatherProc
        command: ["sh", "-c", "curl -sf 'https://wttr.in/Juazeiro?format=%c|%t'"]

        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|")
                var icon = (parts[0] || "󰖐").trim()
                var temperature = (parts[1] || "--ºC").trim().replace("+", "").replace("°C", "ºC")

                weatherLabel = icon + " " + temperature
                weatherTooltip = "Juazeiro\nCondição atual: " + weatherLabel
            }
        }
    }

    Timer {
        id: dateTooltipCloseTimer
        interval: 140
    }

    Component.onCompleted: {
        refreshDateTime()
        weatherProc.running = true
    }
}