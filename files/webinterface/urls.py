from django.conf.urls import patterns, include, url
from django.conf import settings

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('app.views',

    # sites
    url(r'^puppet/site.pp$', 'puppet_site'),

    # addressbook
    url(r'^addressbook/edit/(?P<addr_id>.*)/$', 'addressbook_edit'),
    url(r'^addressbook/$', 'addressbook'),

    # passwords
    url(r'^passwords/$', 'passwords'),

    # peerings
    url(r'^peerings/new/$', 'peerings_edit'),
    url(r'^peerings/(?P<peering_id>.*)/$', 'peerings_edit'),
    url(r'^peerings/$', 'peerings'),

    # changes
    url(r'^apply_changes/run/$', 'apply_changes_run'),
    url(r'^apply_changes/$', 'apply_changes'),

    # API
    url(r'^api/v1/(?P<api_url>.*)$', 'api_v1'),

    # rest
    url(r'^$', 'home'),
    url(r'^admin/', include(admin.site.urls)),

)

if settings.DEBUG:
    urlpatterns += patterns('django.views.static',
        url(r'static/(?P<path>.*)$', 'serve', {'document_root': settings.STATIC_ROOT}),
        url(r'media/(?P<path>.*)$', 'serve', {'document_root': settings.MEDIA_ROOT}),
    )
