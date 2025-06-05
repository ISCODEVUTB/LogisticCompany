# Etapa 1: Construcción de la app Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build web --release

# Etapa 2: Servir la app con nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]