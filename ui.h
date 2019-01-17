void ui_setup(void (*cback)(char *key,int code, int down, int *prop));
void ui_loop();
void ui_sendkeycode(int key);
void ui_sendkeycodedown(int key);
void ui_sendkeycodeup(int key);
