%define debug_package %{nil}
%define _enable_debug_packages 1
%define __os_install_post %{nil}

Name:           sample
Version:        %{version}
Release:        %{release}%{?dist}
Summary:        My sample application

License:        MIT
URL:            None
Source0:        %{name}-%{version}.tar.gz

%define _install_dir /opt/%{name}

%description
This is a sample application.

%package debug
Summary:        Debug version of %{name}
Group:          Development/Debug
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description debug
This package provides a debug version of %{name}.

%prep
%setup -q -c

%build
%{__make} debug
%{__make}

%install
%{__rm} -rf %{buildroot}
mkdir -p %{buildroot}%{_install_dir}/.debug
install -m 755 %{name} %{buildroot}%{_install_dir}
install -m 755 %{name}_debug %{buildroot}%{_install_dir}/.debug
mv %{buildroot}%{_install_dir}/.debug/%{name}_debug %{buildroot}%{_install_dir}/.debug/%{name}

%files
%{_install_dir}/%{name}

%files debug
%{_install_dir}/.debug/%{name}

%changelog


