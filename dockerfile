FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
# Setup NodeJs
RUN apt-get update -qq && \
    apt-get install -qq -y wget && \
    apt-get install -qq -y gnupg2 && \
    wget -qO- https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -qq -y build-essential nodejs && \
    apt-get install -qq -y nginx
# End setup

WORKDIR /app

EXPOSE 80

FROM microsoft/dotnet:2.2-sdk AS build
# Setup NodeJs
RUN apt-get update -qq && \
    apt-get install -qq -y wget && \
    apt-get install -qq -y gnupg2 && \
    wget -qO- https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -qq -y build-essential nodejs && \
    apt-get install -qq -y nginx
# End setup

WORKDIR /source
COPY source/Web/WebApplication1.Web.csproj ./Web/
RUN dotnet restore ./Web/WebApplication1.Web.csproj
COPY source/Web/ClientApp/package.json ./Web/ClientApp/
RUN cd ./Web/ClientApp && npm i --silent
COPY source .

RUN dotnet build ./Web/WebApplication1.Web.csproj -c Release -o /app

FROM build AS publish

RUN dotnet publish ./Web/WebApplication1.Web.csproj -c Release -o /app


FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "WebApplication1.Web.dll"]
