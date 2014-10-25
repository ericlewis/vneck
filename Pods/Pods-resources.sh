#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "ApplePayStubs/Classes/STPTestPaymentSummaryViewController.xib"
install_resource "Facebook-iOS-SDK/src/FBUserSettingsViewResources.bundle"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-camera-button.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-camera-button@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-camera-button@3x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-delete-button.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-delete-button@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-delete-button@3x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-no-connection.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-no-connection@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-powered-by-logo.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-powered-by-logo@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-powered-by-logo@3x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-screenshot-error.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HS-screenshot-error@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSChatBubbleBlue.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSChatBubbleBlue@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSChatBubbleBlue@3x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSChatBubbleWhite.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSChatBubbleWhite@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSChatBubbleWhite@3x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSConfirmBox.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSConfirmBox@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSTutorial.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSTutorial@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSTutorial@3x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSTutorialiPad.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSTutorialiPad@2x.png"
install_resource "Helpshift/helpshift-sdk-ios-v4.9.1/HSResources/HSTutorialiPad@3x.png"
install_resource "NSDate+TimeAgo/NSDateTimeAgo.bundle"
install_resource "PaymentKit/PaymentKit/Resources/Cards/amex.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/amex@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/cvc-amex.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/cvc-amex@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/cvc.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/cvc@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/diners.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/diners@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/discover.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/discover@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/jcb.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/jcb@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/mastercard.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/mastercard@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/placeholder.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/placeholder@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/visa.png"
install_resource "PaymentKit/PaymentKit/Resources/Cards/visa@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/gradient@2x.png"
install_resource "PaymentKit/PaymentKit/Resources/textfield.png"
install_resource "PaymentKit/PaymentKit/Resources/textfield@2x.png"
install_resource "VTAcknowledgementsViewController/VTAcknowledgementsViewController.bundle"
install_resource "${BUILT_PRODUCTS_DIR}/Appirater.bundle"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ `xcrun --find actool` ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in 
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;  
  esac 
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi