function eo_terminal
    cd $EO
    in_new_kitty_window source "e $EO" &&
        in_new_kitty_window console "cd $EO && be rails console" &&
        in_new_kitty_window "木" "cd $EO && de tail -f log/development.log" &&
        in_new_kitty_window "EP木" "cd $EO && docker logs -f exec_online-ep_client-1" &&
        in_new_kitty_window "P3木" "cd $EO && docker logs -f exec_online-p3-1" &&
        in_new_kitty_window "puma木" "cd $EO && docker logs -f exec_online-exo_app-1" &&
        in_new_kitty_window pianoctl pianoctl &&
        in_new_kitty_window saml-okta "cd ~/work/saml && saml-idp --acsUrl 'https://dev-973490.okta.com/sso/saml2/0oapck7q3mWB0dStg356' --audience 'https://www.okta.com/saml2/service-provider/spsxqsdhiidkjmaqpwcv'"
        in_new_kitty_window saml-keycloak "cd ~/work/saml && saml-idp --acsUrl 'https://auth.staging.execonline.com/realms/master/broker/dev-saml-idp/endpoint' --audience 'https://auth.staging.execonline.com/realms/master' --port 7001"
end
