static const std::string passwordHint = PASSWORD_MIME_TYPE;
if (mimeTypes_.contains(passwordHint)) {
    receiveDataForMime(passwordHint, [this, callbackWrapper](const std::vector<char> &data) {
        if (std::string_view(data.data(), data.size()) == "secret" && ignorePassword_) {
            FCITX_CLIPBOARD_DEBUG() << "Wayland clipboard contains password, ignore.";
            return;
        }
        isPassword_ = true;
        receiveRealData(callbackWrapper);
    });
} else {
    receiveRealData(callbackWrapper);
}
