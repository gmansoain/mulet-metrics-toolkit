%dw 2.0
output application/json
---
// sizeOf((payload.feed.*entry map (v,k) -> {
//     title: v.title,
//     isDashboard : (v.content.dict.*key filter ($.@name == "isDashboard"))[0],
//     isVisible : (v.content.dict.*key filter ($.@name == "isVisible"))[0]
// } ) filter ($.isDashboard == "1" and $.isVisible == "1")) default null

sizeOf(payload.entry map ((item, index) -> {
    title: item.name,
    isDashboard: item.content.isDashboard,
    isVisible: item.content.isVisible
}) filter ($.isDashboard == true and $.isVisible == true))