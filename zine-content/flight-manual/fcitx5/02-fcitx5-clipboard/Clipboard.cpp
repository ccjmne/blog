void Clipboard::setText(const QString& text, bool clear)
{
    // ...

    auto* mime = new QMimeData;
    mime->setText(text);
#if defined(Q_OS_MACOS)
    mime->setData("application/x-nspasteboard-concealed-type", text.toUtf8());
#elif defined(Q_OS_UNIX)
    mime->setData("x-kde-passwordManagerHint", QByteArrayLiteral("secret"));
#elif defined(Q_OS_WIN)
    mime->setData("ExcludeClipboardContentFromMonitorProcessing", QByteArrayLiteral("1"));
    mime->setData("CanIncludeInClipboardHistory", {4, '\0'});
    mime->setData("CanUploadToCloudClipboard ", {4, '\0'});
#endif

    // ...
}
