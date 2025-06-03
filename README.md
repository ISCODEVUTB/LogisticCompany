# LogisticCompany
Logistic Company

## Environment Variables for Service Communication

The following environment variables can be set to configure the URLs for communication between backend services. If not set, they will use their default values.

-   `DRIVER_SERVICE_URL`: Specifies the URL for the Driver Service, used by the Routing Service.
    -   Default: `http://localhost:8001/drivers`
-   `ORDER_SERVICE_URL`: Specifies the URL for the Shipping Order Service, used by the Routing Service.
    -   Default: `http://localhost:8002/orders`
-   `TRACKING_SERVICE_URL`: Specifies the URL for the Tracking Service (specifically the track event endpoint), used by the Shipping Order Service.
    -   Default: `http://localhost:8003/tracking/track`
