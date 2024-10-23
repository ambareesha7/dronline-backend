require Protocol

Protocol.derive(Inspect, Proto.AdminAuthentication.LoginRequest, except: [:password])
Protocol.derive(Inspect, Proto.PanelAuthentication.LoginRequest, except: [:password])
Protocol.derive(Inspect, Proto.PanelAuthentication.SignupRequest, except: [:password])

Protocol.derive(Inspect, Proto.PanelAuthentication.RecoverPasswordRequest, except: [:new_password])
