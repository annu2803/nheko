// SPDX-FileCopyrightText: 2021 Nheko Contributors
// SPDX-FileCopyrightText: 2022 Nheko Contributors
//
// SPDX-License-Identifier: GPL-3.0-or-later

import "ui"
import Qt.labs.platform 1.1 as Platform
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2
import QtQuick.Window 2.15
import im.nheko 1.0

Rectangle {
    id: userSettingsDialog

    property int collapsePoint: 800
    property bool collapsed: width < collapsePoint
    color: Nheko.colors.window

    ScrollView {
        id: scroll

        palette: Nheko.colors
        ScrollBar.horizontal.visible: false
        anchors.fill: parent
        anchors.margins: Nheko.paddingLarge

        contentWidth: availableWidth

        Timer {
            id: deadTimer
            interval: 500
        }

        Connections {
            target: scroll.contentItem
            function onContentYChanged() { deadTimer.restart(); }
        }


        GridLayout {
            id: grid

            columns: userSettingsDialog.collapsed ? 1 : 2
            rowSpacing: Nheko.paddingMedium
            columnSpacing: Nheko.paddingMedium

            anchors.fill: parent
            anchors.leftMargin: userSettingsDialog.collapsed ? Nheko.paddingLarge : (userSettingsDialog.width-userSettingsDialog.collapsePoint) * 0.4
            anchors.rightMargin: anchors.leftMargin

            Repeater {
                model: UserSettingsModel

                delegate: Item {
                    required property var model
                    id: r

                    Component.onCompleted: {
                        while (children.length) { 
                            children[0].parent = grid;
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        color: Nheko.colors.text
                        text: model.name
                        //Layout.column: 0
                        Layout.columnSpan: (model.type == UserSettingsModel.SectionTitle && !userSettingsDialog.collapsed) ? 2 : 1
                        //Layout.row: model.index
                        Layout.minimumWidth: implicitWidth
                        Layout.leftMargin: model.type == UserSettingsModel.SectionTitle ? 0 : Nheko.paddingMedium
                        Layout.topMargin: model.type == UserSettingsModel.SectionTitle ? Nheko.paddingLarge : 0
                        font.pointSize: 1.1 * fontMetrics.font.pointSize

                        HoverHandler {
                            id: hovered
                            enabled: model.description ?? false
                        }
                        ToolTip.visible: hovered.hovered && model.description
                        ToolTip.text: model.description ?? ""
                        ToolTip.delay: Nheko.tooltipDelay
                    }

                    DelegateChooser {
                        id: chooser

                        roleValue: model.type
                        Layout.alignment: Qt.AlignRight

                        //Layout.column: model.type == UserSettingsModel.SectionTitle ? 0 : 1
                        Layout.columnSpan: (model.type == UserSettingsModel.SectionTitle && !userSettingsDialog.collapsed) ? 2 : 1
                        //Layout.row: model.index
                        Layout.preferredHeight: child.height
                        Layout.preferredWidth: Math.min(child.implicitWidth, child.width || 1000)
                        Layout.fillWidth: model.type == UserSettingsModel.SectionTitle
                        Layout.rightMargin: model.type == UserSettingsModel.SectionTitle ? 0 : Nheko.paddingMedium

                        DelegateChoice {
                            roleValue: UserSettingsModel.Toggle
                            ToggleButton {
                                checked: model.value
                                onCheckedChanged: model.value = checked
                                enabled: model.enabled
                            }
                        }
                        DelegateChoice {
                            roleValue: UserSettingsModel.Options
                            ComboBox {
                                Layout.preferredWidth: Math.min(200, implicitWidth)
                                width: Math.min(200, implicitWidth)
                                model: r.model.values
                                currentIndex: r.model.value
                                enabled: !deadTimer.running
                                onCurrentIndexChanged: r.model.value = currentIndex
                            }
                        }
                        DelegateChoice {
                            roleValue: UserSettingsModel.Number

                            SpinBox {
                                //implicitWidth: 100
                                enabled: !deadTimer.running && model.enabled
                                from: model.valueLowerBound
                                to: model.valueUpperBound
                                stepSize: model.valueStep
                                value: model.value
                                onValueChanged: model.value = value
                            }
                        }
                        DelegateChoice {
                            roleValue: UserSettingsModel.ReadOnlyText
                            Text {
                                color: Nheko.colors.text
                                text: model.value
                            }
                        }
                        DelegateChoice {
                            roleValue: UserSettingsModel.SectionTitle
                            Item {
                                width: grid.width
                                height: fontMetrics.lineSpacing
                                Rectangle {
                                    anchors.topMargin: Nheko.paddingSmall
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    color: Nheko.colors.buttonText
                                    height: 1
                                }
                            }
                        }
                        DelegateChoice {
                            roleValue: UserSettingsModel.KeyStatus
                            Text {
                                color: model.good ? "green" : Nheko.theme.error
                                text: model.value ? qsTr("CACHED") : qsTr("NOT CACHED")
                            }
                        }
                        DelegateChoice {
                            roleValue: UserSettingsModel.SessionKeyImportExport
                            RowLayout {
                                Button {
                                    text: qsTr("IMPORT")
                                    onClicked: UserSettingsModel.importSessionKeys()
                                }
                                Button {
                                    text: qsTr("EXPORT")
                                    onClicked: UserSettingsModel.exportSessionKeys()
                                }
                            }
                        }
                        DelegateChoice {
                            roleValue: UserSettingsModel.XSignKeysRequestDownload
                            RowLayout {
                                Button {
                                    text: qsTr("DOWNLOAD")
                                    onClicked: UserSettingsModel.downloadCrossSigningSecrets()
                                }
                                Button {
                                    text: qsTr("REQUEST")
                                    onClicked: UserSettingsModel.requestCrossSigningSecrets()
                                }
                            }
                        }
                        DelegateChoice {
                            Text {
                                text: model.value
                            }
                        }
                    }
                }
            }
        }
    }

    ImageButton {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Nheko.paddingMedium
        width: Nheko.avatarSize
        height: Nheko.avatarSize
        image: ":/icons/icons/ui/angle-arrow-left.svg"
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Back")
        onClicked: mainWindow.pop()
    }

}
