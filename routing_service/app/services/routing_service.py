class RouteService:
    def create(self, route_data: RouteCreate):
        return create_route(route_data)

    def get_all(self):
        return get_all_routes()

    def delete(self, route_id: int):
        return delete_route(route_id)
