### Multisite

Note: This is not officially supported or used by DMS, but something we want to keep on our radar should it be needed:

You may need to run several "sites" off of the same Elastic Beanstalk cluster.
This isn't likely a common need, we just wanted to make sure there was *some* room made for this.
More documentation incoming.

If you go multisite you'll need. Your database structure in RDS will look like this:

    mautic_eb_multi     - Database mapping hostnames to sites, based on [this](https://gist.github.com/heathdutton/46fc4514d8372cdda26b61cc0fe6a0cd).
    mautic_eb_site_0    - Default first site in the cluster.
    mautic_eb_site_1    - Second site... and so on.

Multisite environment variables:

    EB_MULTI            - Set to true to enable multisite (off by default).
