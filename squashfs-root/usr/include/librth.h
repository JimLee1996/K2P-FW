#ifndef LIBRTHC_H
#define LIBRTHC_H

extern int phi_inet_is_ok();
extern int phi_wan_link_is_ok();
extern int phi_get_wan_speed(long long *up, long long *down);
extern int phi_port_link_is_ok(int pn);


#endif /* end of include guard: LIBRTHC_H */
