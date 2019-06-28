# docker build -t nginx_with_upload_module:1.2.0 .
FROM centos:7.5.1804
RUN yum install -y make gcc gcc-c++ pcre-devel zlib-devel openssl openssl-devel \
#  编译安装Nginx
&& mkdir /docker_download && cd /docker_download \
&& curl -O http://nginx.org/download/nginx-1.2.0.tar.gz \
&& tar zxvf nginx-*.tar.gz \
&& rm -rf nginx-*.tar.gz \
&& cd  nginx-* \
&& ./configure --prefix=/usr/local/nginx --with-http_ssl_module \
&& make && make install \
# 安装nginx_upload_module模块
&& cd /docker_download \
&& curl -O http://www.grid.net.ru/nginx/download/nginx_upload_module-2.2.0.tar.gz \
&& tar -zxvf nginx_upload_module*.tar.gz \
&& rm -rf nginx_upload_module*.tar.gz \
&& mv nginx_upload_module-* nginx_upload_module \
&& cd /docker_download/nginx_upload_module \
&& sed -i 's/int          result;/__attribute__((__unused__)) int result;/g' ngx_http_upload_module.c \
&& cd /docker_download/nginx-* \
&& ./configure --add-module=/docker_download/nginx_upload_module \
&& make \
# 不要make install
&& mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.bak \
&& cp -rf ./objs/nginx /usr/local/nginx/sbin/nginx \
&& rm -rf /docker_download \
&& mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
COPY ./nginx.conf /usr/local/nginx/conf/