FROM dart:stable
WORKDIR /app
COPY . .
RUN dart pub get
EXPOSE 8080
CMD ["dart", "run", "dart_frog", "serve", "--port", "8080"]
