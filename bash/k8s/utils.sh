klogs() {
    # Define the environment-to-namespace mapping
    case "$1" in
        u) namespace="service-uat" ;;
        p) namespace="service-production" ;;
        s) namespace="service-staging" ;;
        d) namespace="service-dev" ;;
        *)
            echo "Invalid environment. Use 'u' for uat, 'p' for production, 's' for staging, 'd' for >
            return 1
            ;;
    esac

    # Get the pod pattern
    pattern="$2"
    if [ -z "$pattern" ]; then
        echo "Usage: k_logs <env> <pattern>"
        return 1
    fi

    # Find the first pod matching the pattern
    pod_names=$(ku get pod | grep "$pattern" | cut -d' ' -f1)
    echo Pod found $pod_names
    if [ -z "$pod_names" ]; then
        echo "No pod found matching the pattern '$pattern' in environment '$1'."
        return 1
    fi

    # Convert pod_names to an array
    IFS=$'\n' read -rd '' -A pods <<< "$pod_names"

    if [ ${#pods[@]} -gt 1 ]; then
        echo "Multiple pods found. Please choose one:"
        select pod_name in "${pods[@]}"; do
            if [ -n "$pod_name" ]; then
                kubectl -n "$namespace" logs -f  "$pod_name"
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
    else
        pod_name=${pods[0]}
        kubectl -n "$namespace" logs -f "$pod_name"
    fi
}