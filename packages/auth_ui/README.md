# auth_ui

Optional, replaceable authentication presentation helpers.

It provides `SignInCubit<C>`, validators, a text-field primitive, and a submit
button. The Cubit accepts only a typed `SignIn<C>` use case. Apps retain screen
layout, branding, copy, enabled methods, form controllers, and navigation.

This package intentionally does not expose fixed product screens, gateways,
storage, networking, or routing policy. Consumers may omit it and build their
own presentation directly on `auth_core`.
