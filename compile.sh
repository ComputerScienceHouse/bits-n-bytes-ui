#!/bin/bash

compile_ui() {
    case $1 in
        resources)
            pyside6-rcc resources/resources.qrc -o resources_rc.py 
            ;;
        welcome)
            pyside6-uic ui/welcome_screen.ui -o screens/ui_welcome.py
            ;;
        cart)
            pyside6-uic ui/cart_screen.ui -o screens/ui_cart.py
            ;;
        receipt)
            pyside6-uic ui/reciept_screen.ui -o screens/ui_reciept.py
            ;;
        admin)
            pyside6-uic ui/admin_screen.ui -o screens/ui_admin.py
            ;;
        all)
            pyside6-rcc resources/resources.qrc -o resources_rc.py 
            pyside6-uic ui/welcome_screen.ui -o screens/ui_welcome.py
            pyside6-uic ui/cart_screen.ui -o screens/ui_cart.py
            pyside6-uic ui/reciept_screen.ui -o screens/ui_reciept.py
            pyside6-uic ui/admin_screen.ui -o screens/ui_admin.py
            ;;
        *)
            echo "Invalid option: $1"
            echo "Usage: $0 {resources|welcome|cart|receipt|admin|all}"
            exit 1
            ;;
    esac
}

for arg in "$@"
do
    compile_ui "$arg"
done
