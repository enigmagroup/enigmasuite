from django import forms
from django.core.validators import validate_slug, validate_ipv6_address

class AddressbookForm(forms.Form):
    name = forms.CharField(initial='', validators=[validate_slug])
    ipv6 = forms.CharField(initial='', validators=[validate_ipv6_address])
    phone = forms.IntegerField(initial='', min_value=10, required=False)

class PeeringsForm(forms.Form):
    address = forms.CharField(initial='', required=True)
    public_key = forms.CharField(initial='', required=True, min_length=54, max_length=54)
    password = forms.CharField(initial='', required=True)
    country = forms.CharField(initial='', required=False, min_length=2, max_length=2)
    description = forms.CharField(initial='', required=False)

