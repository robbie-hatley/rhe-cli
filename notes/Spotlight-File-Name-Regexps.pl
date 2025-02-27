# Gibberish pattern:
$main::gibpat = qr(^[a-z]{8}(?:-\(\d{4}\))?(?:\.[a-zA-Z]+)?$);

# Windows SpotLight pattern:
$main::wslpat = qr(^[0-9a-f]{64}(?:-\(\d{4}\))?(?:\.[a-zA-Z]+)?$);

# SHA1 hash pattern:
$main::shapat = qr(^[0-9a-f]{40}(?:-\(\d{4}\))?(?:\.[a-zA-Z]+)?$);

