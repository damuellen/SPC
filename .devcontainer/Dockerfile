FROM swift:5.8

# [Option] Install zsh
ARG INSTALL_ZSH="false"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get autoremove -y && apt-get clean -y

COPY library-scripts/libxlsxwriter.sh /tmp/library-scripts/
COPY library-scripts/swift-format.sh /tmp/library-scripts/
COPY library-scripts/wkhtmltox.sh /tmp/library-scripts/

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libsqlite3-dev gnuplot-nox \
    && apt-get -y install make build-essential

RUN /bin/bash /tmp/library-scripts/libxlsxwriter.sh \
    && /bin/bash /tmp/library-scripts/swift-format.sh \
    && /bin/bash /tmp/library-scripts/wkhtmltox.sh \
    && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/library-scripts
