FROM python:3.10-slim
ENV PYTHONDONTWRITEBYTECODE=1
USER root
RUN apt-get update && apt-get install -y libsndfile1-dev espeak-ng time git cmake wget xz-utils build-essential g++5 libprotobuf-dev protobuf-compiler
ENV VIRTUAL_ENV=/usr/local
RUN pip --no-cache-dir install uv && uv venv && uv pip install --no-cache-dir -U pip setuptools

RUN wget https://github.com/ku-nlp/jumanpp/releases/download/v2.0.0-rc4/jumanpp-2.0.0-rc4.tar.xz
RUN tar xvf jumanpp-2.0.0-rc4.tar.xz
RUN mkdir jumanpp-2.0.0-rc4/bld
WORKDIR ./jumanpp-2.0.0-rc4/bld
RUN curl -LO https://github.com/catchorg/Catch2/releases/download/v2.13.8/catch.hpp
RUN mv catch.hpp ../libs/
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
RUN make install


RUN uv pip install --no-cache --upgrade 'torch' --index-url https://download.pytorch.org/whl/cpu
RUN uv pip install --no-cache-dir  --no-deps accelerate --extra-index-url https://download.pytorch.org/whl/cpu 
RUN uv pip install  --no-cache-dir "transformers[ja,testing,sentencepiece,jieba,spacy,ftfy,rjieba]" unidic unidic-lite spacy 
RUN python3 -m unidic download
RUN pip uninstall -y transformers

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt remove -y g++ cmake  xz-utils libprotobuf-dev protobuf-compiler