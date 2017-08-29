var old_v2_version = "2.2.13";
var new_v3_version = "3.3.1";
var old_v2_list = document.getElementsByClassName("oldV2Version");
var new_v3_list = document.getElementsByClassName("newV3Version");
for (i = 0; i < old_v2_list.length; i++) {
  old_v2_list[i].innerHTML = old_v2_version;
}
for (i = 0; i < new_v3_list.length; i++) {
  new_v3_list[i].innerHTML = new_v3_version;
}
