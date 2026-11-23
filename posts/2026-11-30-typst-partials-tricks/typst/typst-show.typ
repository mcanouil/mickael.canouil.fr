#show: doc => article(
  lang: "$if(lang)$$lang$$else$en$endif$",
  region: "GB",
  sectionnumbering: $if(section-numbering)$"$section-numbering$"$else$none$endif$,
  doc,
)
#set document(title: "$title$")
#title-block(
  title: [$title$],
$if(kicker)$  kicker: [$kicker$],
$endif$$if(subtitle)$  subtitle: [$subtitle$],
$endif$$if(date)$  date: [$date$],
$endif$)
