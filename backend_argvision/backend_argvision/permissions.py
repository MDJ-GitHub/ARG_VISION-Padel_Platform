from rest_framework import permissions

class IsAdmin(permissions.BasePermission):
    """
    Global permission check for Admin users.
    """
    message = 'Only Admin users can access this resource.'

    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'Admin'

class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Allows read-only access to all users, but write access only to Admin users.
    """
    message = 'Only Admin users can modify this resource.'

    def has_permission(self, request, view):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions are only allowed to Admin users.
        return request.user.is_authenticated and request.user.role == 'Admin'
    
class IsOwner(permissions.BasePermission):
    message = 'Only the Terrain Owners users can access this resource.'

    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'Owner'

class IsOwnerOrReadOnly(permissions.BasePermission):
    message = 'Only the Terrain Owners users can modify this resource.'

    def has_permission(self, request, view):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions are only allowed to Admin users.
        return request.user.is_authenticated and request.user.role == 'Owner'